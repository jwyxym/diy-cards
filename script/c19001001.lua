--日出映画
function c19001001.initial_effect(c)
	aux.AddCodeList(c,19000072,19001001)
	--change name
	aux.EnableChangeCode(c,19000072,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19001001+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c19001001.activate)
	c:RegisterEffect(e1)
	--draw
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetDescription(aux.Stringid(19001001,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e5:SetTarget(c19001001.drtg)
	e5:SetOperation(c19001001.drop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_FZONE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetLabelObject(e5)
	e6:SetOperation(c19001001.regop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_CHAIN_NEGATED)
	e7:SetOperation(c19001001.regop2)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e8:SetOperation(c19001001.clearop)
	c:RegisterEffect(e8)
end
function c19001001.thfilter(c)
	return (c:IsCode(19000072) or (aux.IsCodeListed(c,19000072) and not c:IsCode(19001001))) and c:IsAbleToHand()
end
function c19001001.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c19001001.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19001001,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c19001001.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(19000067,19000068,19000069,19000071,19000073,19001000) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local val=e:GetLabelObject():GetLabel()
		e:GetLabelObject():SetLabel(val+1)
	end
end
function c19001001.regop2(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(19000067,19000068,19000069,19000071,19000073,19001000) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local val=e:GetLabelObject():GetLabel()
		if val==0 then val=1 end
		e:GetLabelObject():SetLabel(val-1)
	end
end
function c19001001.clearop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
function c19001001.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=e:GetLabel()
	if chk==0 then return d>0 and Duel.IsPlayerCanDraw(tp,d) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,d)
end
function c19001001.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=e:GetLabel()
	if d>0 then
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
