--最强的吸血鬼杀手·祖斯特
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddCodeList(c,80485722)
	
	--不能通常召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e0)
	
	--不能盖放
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0b:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e0b)
	
	--不能用其他效果特殊召唤
	local e0c=Effect.CreateEffect(c)
	e0c:SetType(EFFECT_TYPE_SINGLE)
	e0c:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0c:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0c:SetValue(s.splimit)
	c:RegisterEffect(e0c)
	
	--墓地有3只以上吸血鬼才能从手卡·墓地特殊召唤
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_FIELD)
	e00:SetCode(EFFECT_SPSUMMON_PROC)
	e00:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e00:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e00:SetCondition(s.spcon)
	c:RegisterEffect(e00)
	
	--①效果：卡名当作「吸血鬼杀手」使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(80485722)
	c:RegisterEffect(e1)
	
	--②效果：展示手卡这张卡，检索，然后丢弃
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	
	--③效果：对方不能把不死族怪兽的效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.con3)
	e3:SetValue(s.actlimit)
	c:RegisterEffect(e3)
end

function s.splimit(e,se,sp,st)
	return se and se:GetHandler()==e:GetHandler()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x8e)>=3
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end

function s.thfilter(c)
	return (c:IsCode(80485722) or (aux.IsCodeListed(c,80485722) and c:IsType(TYPE_SPELL+TYPE_TRAP))) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToEffect(e) then
			Duel.SendtoGrave(c,REASON_EFFECT+REASON_DISCARD)
		end
	end
end

function s.con3(e)
	return e:GetHandler():IsFaceup()
end

function s.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRace(RACE_ZOMBIE)
end

return s
