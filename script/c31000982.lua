--银河时空影龙
local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon（龙族4星怪兽×2）
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),4,2)
	c:EnableReviveLimit()
	--① 自己主要阶段才能发动（这个效果发动的回合，自己不是龙族怪兽不能特殊召唤）。自己场上2个超量素材取除，从卡组把1只攻击力2000的龙族·8星怪兽或者「时空」怪兽加入手卡。那之后，可以把这张卡的控制权移给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--② 只要自己场上有「银河眼时空龙」怪兽存在，自己场上的「时空」怪兽不受除以自己场上的卡为对象的效果以外的对方发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.immtg)
	e2:SetValue(s.immval)
	e2:SetCondition(s.immcon)
	c:RegisterEffect(e2)
	--③ 结束阶段发动。场上的全部怪兽的控制权回归原本持有者。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.ctrcon)
	e3:SetTarget(s.ctrtg)
	e3:SetOperation(s.ctrop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsRace(RACE_DRAGON)
end
--这个效果发动的回合，自己不是龙族怪兽不能特殊召唤
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local xg=Group.CreateGroup()
	local mg=Duel.GetMatchingGroup(s.ovfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(mg) do
		xg:Merge(tc:GetOverlayGroup())
	end
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and xg:GetCount()>=2 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	local cost=xg:Select(tp,2,2,nil)
	Duel.SendtoGrave(cost,REASON_COST)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_DRAGON)
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and ((c:IsRace(RACE_DRAGON) and c:IsLevel(8) and c:IsAttack(2000)) or c:IsSetCard(0x1b4))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.GetControl(c,1-tp)
	end
end
function s.gfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x307b)
end
function s.immcon(e)
	return Duel.IsExistingMatchingCard(s.gfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.immtg(e,c)
	return c:IsSetCard(0x1b4)
end
function s.immval(e,re)
	local tp=e:GetHandlerPlayer()
	if re:GetOwnerPlayer()==tp then return false end
	if not re:IsActivated() then return false end
	-- 以自己场上的卡为对象的效果不免疫：连锁解决时目标已确定（参考 c70405001）
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if g and g:IsExists(Card.IsControler,1,nil,tp) then
			return false
		end
	end
	-- 持续效果通过 SetCardTarget 登记的目标（目标已固定在效果持有者卡上）
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	return not g:IsExists(function(tc) return re:GetHandler():IsHasCardTarget(tc) end,1,nil)
end
function s.ctrcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.ctrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	local tg=g:Filter(function(tc) return tc:GetControler()~=tc:GetOwner() end,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tg,tg:GetCount(),0,0)
end
function s.ctrop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	for tc in aux.Next(g) do
		if tc:GetControler()~=tc:GetOwner() then
			Duel.GetControl(tc,tc:GetOwner())
		end
	end
end
