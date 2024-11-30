--生死决速
local s,id,o=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,11100315)
	--activate
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--up atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) 
	return c:IsCode(11100315) end)
	e2:SetValue(s.adval)
    c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.tkcon)
	e3:SetTarget(s.tktg)
	e3:SetOperation(s.tkop)
	c:RegisterEffect(e3)
    --damge
    local e4=Effect.CreateEffect(c)
    e4:SetRange(LOCATION_FZONE)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetCountLimit(1)
    e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
--贴场地
function s.setfilter(c,tp)
	return c:IsCode(11100321) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(1-tp)
end
function s.thfilter(c)
    return c:IsCode(11100315) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
        local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=g:Select(tp,1,1,nil)
            Duel.BreakEffect()
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
	end
end
--up atk
function s.adval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetOwnerPlayer(),0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then
		return 0
	else
		local tg,val=g:GetMaxGroup(Card.GetBaseAttack)
		return val
	end
end
--token sps
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,11100339,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_WARRIOR,ATTRIBUTE_LIGHT,POS_FACEUP,1-tp) then
		local token=Duel.CreateToken(tp,11100339)
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
--damge
function s.damcon(e)
	local c=e:GetHandler()
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	return g1:GetSum(Card.GetAttack)<g2:GetSum(Card.GetAttack) and tp==Duel.GetTurnPlayer()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,2000,REASON_EFFECT)
end
