--不弑的使徒
local s,id,o=GetID()
function s.initial_effect(c)
	--卡组检索
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--效破耐性    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
    e3:SetCondition(s.indcon)
	e3:SetTarget(s.indtg)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	--回复    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.rctg)
	e4:SetOperation(s.rcop)
	c:RegisterEffect(e4)
end
function s.thfilter(c)
	return c:IsSetCard(0xaca1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsAbleToHand() or c:IsSSetable())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SSet(tp,tc)
		end
	end
end
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaca1) and c:IsLevelAbove(5)
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.indtg(e,c)
	return c:IsSetCard(0xaca1) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_MZONE,nil)*400
	if chk==0 then return rc>0 end	
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(rc)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rc)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local rc=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_MZONE,nil)*400
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Recover(p,rc,REASON_EFFECT)
end