--[[
本lua的作者为藜奴儿，如果测试出bug请联系QQ：1502939196
未经允许不支持任何人的任何形式的修改，源数。如有需要请联系作者，而不是私自找人代为修改。
本人对于本lua的任何bug修改、源数和适配后来卡片均为免费，并且追诉期无限。

但是如果使用者私自修改了lua，不论是bug修复还是源数效果，本人对此lua都不会再提供任何形式的支持。
一旦发现任何其他人对本lua进行了任何形式的修改，本人首先自愿放弃此lua除必要署名权以外的所有权利，
同时再也会不承担对此lua的任何维护与后续适配，包括但不限于任何形式的bug修复、效果源数。

如果您想要修改此lua，可以先联系本人，本人会在第一时间进行回复。
并且我承诺，若本人在2天内没有回复您，上述注意事项可作废，您可以直接修改此lua，而后续debug与适配仍然由我来进行。

如果您对本lua有任何疑问，请联系本人，本人会在第一时间进行回复。
如果您对本lua有任何建议，请联系本人，本人会在第一时间进行处理。
]]
local s,id,o=GetID()
function s.initial_effect(c)
	-- 永续陷阱发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在自己场上表侧表示存在，对方回合内，对方场上的特殊召唤的表侧表示怪兽在「冥骸驱轮」怪兽的超量召唤使用的场合，可以把那些怪兽的等级当作5星使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(s.regop)
	Duel.RegisterEffect(e1,0)
	-- ②：这个卡名的②效果1回合只能使用1次。自己场上的其他卡为对象的效果由对方发动时才能发动。那个效果无效并破坏。那之后，选自己场上·除外状态的1张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：1回合最多2次（同一连锁上最多1次），对方召唤·特殊召唤的场合，以自己场上1只「冥骸驱轮」怪兽为对象才能发动。以包含作为对象的怪兽和相同纵列的其他怪兽作为超量素材，从额外卡组把1只「冥骸驱轮」超量怪兽超量召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(2)
	e3:SetCondition(s.xyzcon)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- effect ①
function s.lvfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.lvcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_SZONE,1,nil)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(id)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
			local g=Duel.GetMatchingGroup(s.lvfilter,p,0,LOCATION_MZONE,nil)
			for tc in aux.Next(g) do
				if tc:GetFlagEffect(id+500+p)==0 then
					tc:RegisterFlagEffect(id+500+p,RESET_EVENT+RESETS_STANDARD,0,1)
					local e1=Effect.CreateEffect(tc)
					e1:SetDescription(aux.Stringid(id,3))
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_XYZ_LEVEL)
					e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetRange(LOCATION_MZONE)
					e1:SetCondition(s.lvcon)
					e1:SetValue(s.lvval)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
				end
			end
		end
	
end
function s.lvval(e,c,rc)
	if rc and rc:IsSetCard(0xa460) then
		return c:GetLevel()+0x50000
	else
		return c:GetLevel()
	end
end
-- effect ②
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsExists(s.tfilter,1,nil,tp,e:GetHandler()) then return false end
	return Duel.IsChainNegatable(ev)
end
function s.tfilter(c,tp,exc)
	return c:IsOnField() and c:IsControler(tp) and c~=exc
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.thfilter(c,tp)
	return c:IsControler(tp) and c:IsAbleToHand()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD+LOCATION_REMOVED,0,1,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_ONFIELD+LOCATION_REMOVED,0,1,1,nil,tp)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- effect ③
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function s.xyztgfilter(c,tp)
	local tg=c:GetColumnGroup():Filter(Card.IsType,nil,TYPE_MONSTER)
	local tc=tg:GetFirst()
	if not tc then return false	end
	local mg=Group.FromCards(tc,c)
	return c:IsFaceup() and c:IsSetCard(0xa460) and c:IsControler(tp) 
		and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
function s.exfilter(c,mg)
	return c:IsSetCard(0xa460) and c:IsXyzSummonable(mg,#mg,#mg)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyztgfilter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then
		if c:GetFlagEffect(id+100)~=0 then return false end
		return Duel.IsExistingTarget(s.xyztgfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	c:RegisterFlagEffect(id+100,RESET_CHAIN,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local cg=tc:GetColumnGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	cg:AddCard(tc)
	local xyzg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA,0,nil,cg)
	if xyzg:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
	Duel.XyzSummon(tp,xyz,cg)
end
