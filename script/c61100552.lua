--山樱剑技-终焉樱
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,61100540)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_DRAW)
	e1a:SetType(EFFECT_TYPE_ACTIVATE)
	e1a:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1a:SetCode(EVENT_BE_BATTLE_TARGET)
	e1a:SetCondition(s.con2)
	e1a:SetTarget(s.tg2)
	e1a:SetOperation(s.op2)
	c:RegisterEffect(e1a)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsFaceup() and (tc:IsType(TYPE_FUSION) or tc:IsSetCard(0x57b))
end
function s.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and (c:IsType(TYPE_FUSION) or c:IsSetCard(0x57b)) and c:IsControler(tp)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	if e==re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsOnField() and g:IsExists(s.tfilter,1,nil,tp)
end
function s.filter5(c,ct)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=ev
	local label=Duel.GetFlagEffectLabel(0,id)
	if label then
		if ev==bit.rshift(label,16) then ct=bit.band(label,0xffff) end
	end
	if chkc then return chkc:IsOnField() and s.filter5(chkc,ct) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter5,tp,0,LOCATION_MZONE,1,e:GetLabelObject(),ct) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter5,tp,0,LOCATION_MZONE,1,1,e:GetLabelObject(),ct)
	local val=ct+bit.lshift(ev+1,16)
	if label then
		Duel.SetFlagEffectLabel(0,id,val)
	else
		Duel.RegisterFlagEffect(0,id,RESET_CHAIN,0,1,val)
	end
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,Duel.GetAttacker()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,Duel.GetAttacker())
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local a=Duel.GetAttacker()
	if not (tc and tc:IsRelateToEffect(e)
		and a:IsAttackable() and not a:IsImmuneToEffect(e)) then return end
		Duel.CalculateDamage(a,tc)
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
	local b1=tc:IsRelateToEffect(e)
	local b2=Duel.IsPlayerCanDraw(tp,1)
	local b3=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,tp)
	if #g>0 and (b1 or b2 or b3) then
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)},{true,aux.Stringid(id,3)})
		if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.Destroy(dg,REASON_EFFECT)
		Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
		elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		local fc=dg:GetFirst()
		if Duel.Destroy(fc,REASON_EFFECT)>0 then
		Duel.Draw(tp,math.floor(fc:GetLevel()/3),REASON_EFFECT)
		end
		elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		local sdg=Duel.Destroy(dg,REASON_EFFECT)
		local oppg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil)
		if #oppg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local dc=oppg:Select(tp,1,1,nil):GetFirst()
			Duel.SSet(tp,dc,REASON_EFFECT)
			if dc:IsType(TYPE_TRAP) and sdg>0 and aux.IsCodeListed(dc,dg:GetFirst():GetCode()) then
				local e1a=Effect.CreateEffect(c)
				e1a:SetDescription(aux.Stringid(id,4))
				e1a:SetType(EFFECT_TYPE_SINGLE)
				e1a:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1a:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1a:SetReset(RESET_EVENT+RESETS_STANDARD)
				dc:RegisterEffect(e1a)
				end
			end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.actlimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.filter1(c,tp)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x57b) and not c:IsCode(id) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x57b)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
	local b1=tc:IsRelateToEffect(e)
	local b2=Duel.IsPlayerCanDraw(tp,1)
	local b3=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,tp)
	if #g>0 and (b1 or b2 or b3) then
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)},{true,aux.Stringid(id,3)})
		if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.Destroy(dg,REASON_EFFECT)
		Duel.Damage(1-tp,math.floor(tc:GetAttack()/2),REASON_EFFECT)
		elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		local fc=dg:GetFirst()
		if Duel.Destroy(fc,REASON_EFFECT)>0 then
		Duel.Draw(tp,math.floor(fc:GetLevel()/3),REASON_EFFECT)
		end
		elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		local sdg=Duel.Destroy(dg,REASON_EFFECT)
		local oppg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil)
		if #oppg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local dc=oppg:Select(tp,1,1,nil):GetFirst()
			Duel.SSet(tp,dc,REASON_EFFECT)
			if dc:IsType(TYPE_TRAP) and sdg>0 and aux.IsCodeListed(dc,dg:GetFirst():GetCode()) then
				local e1a=Effect.CreateEffect(c)
				e1a:SetDescription(aux.Stringid(id,4))
				e1a:SetType(EFFECT_TYPE_SINGLE)
				e1a:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1a:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1a:SetReset(RESET_EVENT+RESETS_STANDARD)
				dc:RegisterEffect(e1a)
				end
			end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.actlimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.actlimit(e,re,tp)
	return re:GetHandler():IsCode(id)
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(61100540)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end