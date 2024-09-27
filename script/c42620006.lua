--学园孤岛 直树美纪
local m=42620006
local cm=_G["c"..m]

function cm.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,m+1)
	e2:SetCondition(cm.cscon)
	e2:SetCost(cm.cscost)
	e2:SetTarget(cm.cstg)
	e2:SetOperation(cm.csop)
	c:RegisterEffect(e2)
	--adjust
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,m)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end

function cm.cscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetCurrentScale()~=7
end

function cm.costcfilter(c)
	return not c:IsPublic() and c:IsLevel(6) and c:IsType(TYPE_PENDULUM) and c:IsAbleToExtra()
end

function cm.cscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.costcfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,cm.costcfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabelObject(tc)
end

function cm.cstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,tc,1,0,0)
end

function cm.csop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(7)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		c:RegisterEffect(e2)
		if c:GetCurrentScale()==7 and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_HAND) then
			Duel.SendtoExtraP(tc,nil,REASON_EFFECT)
		end
	end
end

function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetCurrentChain()>1 then
		local te=Duel.GetChainInfo(Duel.GetCurrentChain()-1,CHAININFO_TRIGGERING_EFFECT)
		if te:IsActiveType(0x6) and te:IsHasType(EFFECT_TYPE_ACTIVATE) then
			e:SetCategory(e:GetCategory()|CATEGORY_REMOVE)
			local tc=te:GetHandler()
			e:SetLabelObject(tc)
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,nil,nil)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end

function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,500,REASON_EFFECT)
	local tc=e:GetLabelObject()
	if tc and tc:IsLocation(0x1c) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end