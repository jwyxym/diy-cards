--极星永续陷阱
local s,id=GetID()
function s.initial_effect(c)
	--Activate 可以随时翻开
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	
	--①效果：选1个发动（二速）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

function s.filter1(c)
	return c:IsFaceup() and (c:IsSetCard(0x42) or c:IsSetCard(0x4B))
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x6042) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.atkfilter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,2,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp)
	local b3=Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	local sel=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)},{b3,aux.Stringid(id,3)})
	e:SetLabel(sel)
	if sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,2,2,nil)
		g1:Merge(g2)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,3,0,0)
	elseif sel==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
	elseif sel==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_NONE,g,1,0,0)
	end
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if g and #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif sel==2 then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if g and #g>0 then
			if g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)~=#g then return end
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			for tc in aux.Next(g) do
				if tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
					local e4=Effect.CreateEffect(e:GetHandler())
					e4:SetType(EFFECT_TYPE_SINGLE)
					e4:SetCode(EFFECT_DISABLE)
					e4:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e4)
					local e5=e4:Clone()
					e5:SetCode(EFFECT_DISABLE_EFFECT)
					tc:RegisterEffect(e5)
				end
			end
		end
		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e6:SetTargetRange(1,0)
		e6:SetTarget(s.splimit)
		e6:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e6,tp)
	elseif sel==3 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
	end
end

function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x4B)
end

return s