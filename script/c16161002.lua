--流星与少女之夜
local m=16161002
local cm=_G["c"..m]
function cm.initial_effect(c)
	aux.AddCodeList(c,16161000)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	--remove and recover
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PAY_LPCOST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m+100)
	e2:SetCondition(cm.tgcon)
	e2:SetOperation(cm.tgop)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE) 
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(cm.condition)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then return true end
					end
					)
	e3:SetOperation(function (e,tp)
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_FIELD)
						e1:SetCode(EFFECT_CANNOT_ACTIVATE)
						e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
						e1:SetTargetRange(0,1)
						e1:SetValue(function(ce,cre,ctp)
										return not cre:GetHandler():IsLocation(LOCATION_ONFIELD)
									end)
						e1:SetReset(RESET_PHASE+PHASE_END)
						Duel.RegisterEffect(e1,tp)
					end)
	c:RegisterEffect(e3)
	
	if not cm.global_check then
		cm.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(cm.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function cm.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsLevelAbove(10) and tc:IsType(TYPE_RITUAL) then
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),m,RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
function cm.check(c)
	return c:IsAbleToHand() and ((aux.IsCodeListed(c,16161000) and c:IsType(TYPE_MONSTER)) or c:IsCode(16161000)) 
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.check,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.activate(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.check,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then  
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end
function cm.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp 
end
function cm.tgop(e,tp,eg,ep,ev,re,r,rp)
	local rec_do_you=Duel.Recover
	function Duel.Recover(pl,val,reason,step)
		if pl==tp then
			val=val*2
			Duel.Recover=rec_do_you
		end
		return rec_do_you(pl,val,reason,step)
	end
end
function cm.condition(e,tp)
	return Duel.GetFlagEffect(tp,m)>0
end