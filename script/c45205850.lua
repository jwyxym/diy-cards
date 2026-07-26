--探寻圣诞异常而来的侦探
local s,id=GetID()
function s.initial_effect(c)
	--①效果：选1个发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

function s.filter1(c)
	return c:IsFaceup() and (c:IsRace(RACE_SPELLCASTER) or c:IsType(TYPE_FLIP))
end

function s.filter3(c)
	return c:IsFacedown()
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local sel=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})
	e:SetLabel(sel)
	if sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
		local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
		local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,2,nil)
		g1:Merge(g2)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,g1:GetCount(),0,0)
	elseif sel==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
		local g=Duel.SelectTarget(tp,s.filter3,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	end
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if g and #g>0 then
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	elseif sel==2 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
			if (tc:IsRace(RACE_SPELLCASTER) or tc:IsType(TYPE_FLIP))
				and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
				if #rg>0 then
					Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
				end
			end
		end
	end
end

return s