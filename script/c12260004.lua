--山水-花池
function c12260004.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12260004,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,12260004+10)
	e1:SetTarget(c12260004.sptg)
	e1:SetOperation(c12260004.spop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12260004,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,12264002+100)
	e2:SetTarget(c12260004.efftg)
	e2:SetOperation(c12260004.effop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP)
	c:RegisterEffect(e4)
end

function c12260004.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end

function c12260004.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12260004.filter(chkc) end
	if chk==0 then 
		return Duel.IsExistingTarget(c12260004.filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,c12260004.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function c12260004.spfilter(c)
	return c:IsFacedown() and c:IsCanTurnSet()
end

function c12260004.trunfilter(c)
	return c:IsFacedown() and c:IsCanChangePosition()
end

function c12260004.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g = Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg = g:Filter(Card.IsRelateToEffect,nil,e)

	if tg:GetCount() > 0 and Duel.ChangePosition(tg:GetFirst(), POS_FACEDOWN_DEFENSE) ~= 0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) ~= 0  then 
			local fid=c:GetFieldID()
			c:RegisterFlagEffect(12260004,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabel(fid)
			e1:SetLabelObject(c)
			e1:SetCondition(c12260004.retcon)
			e1:SetOperation(c12260004.retop)
			Duel.RegisterEffect(e1,tp)
		
			if Duel.IsExistingTarget(c12260004.trunfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(12260004,5))then
				local ttc = Duel.SelectMatchingCard(tp,c12260004.trunfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
				if ttc:GetCount() >  0 then
					local op = Duel.SelectOption(tp,aux.Stringid(12260004,0), aux.Stringid(12260004,1))
					if op==0 then
						Duel.ChangePosition(tg:GetFirst(), POS_FACEUP_ATTACK)
					elseif op == 1 then
						Duel.ChangePosition(tg:GetFirst(), POS_FACEUP_DEFENSE)
					end
				end
			end
		end
	end

end

function c12260004.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(12260004)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end

function c12260004.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end

function c12260004.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function c12260004.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.SelectOption(tp,aux.Stringid(12260004,2),aux.Stringid(12260004,3),aux.Stringid(12260004,4))
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	elseif op==1 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1)
		e1:SetCondition(c12260004.spcon)
		e1:SetOperation(c12260004.spop2)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		Duel.Hint(HINT_CARD,0,12260004)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	else
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function c12260004.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummonMonster,1-tp,LOCATION_EXTRA,0,1,nil)
end
function c12260004.spop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,12260004)
	local p=1-tp
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(p,Card.IsCanBeSpecialSummonMonster,p,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,p,p,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(tp,g)
	end
	e:Reset()
end